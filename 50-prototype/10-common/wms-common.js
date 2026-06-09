/* ================================================================
   WMS 화면 프로토타입 공통 스크립트
   - 모든 메뉴 HTML은 <script src="../common/wms-common.js"></script>
   - 이 파일 로드 후 화면 고유 스크립트를 작성한다.
   ================================================================ */

/* ── 공통 팝업 연동 (거래처 / 품목) ───────────────────────────────
   사용 예: <button class="btn-popup" onclick="openCpPopup('s_cpctNm')">🔍</button>
   타입이 input/select 등 아무 엘리먼트면 .value 에 채운다.
*/
var _cpTargetId = null;
function openCpPopup(targetId) {
  _cpTargetId = targetId;
  window.parent.postMessage({ type: 'OPEN_CP_LAYER' }, '*');
}

var _pdTargetId = null;
function openPdPopup(targetId) {
  _pdTargetId = targetId;
  window.parent.postMessage({ type: 'OPEN_PD_LAYER' }, '*');
}

/* 인라인 그리드용: 선택 결과를 사용자 콜백에 전달한다.
   openCpPopupCb(function(cp) { ... }) 형태로 호출.
*/
var _cpCallback = null;
function openCpPopupCb(cb) {
  _cpCallback = cb;
  window.parent.postMessage({ type: 'OPEN_CP_LAYER' }, '*');
}
var _pdCallback = null;
function openPdPopupCb(cb) {
  _pdCallback = cb;
  window.parent.postMessage({ type: 'OPEN_PD_LAYER' }, '*');
}

window.addEventListener('message', function(e) {
  if (!e.data) return;

  if (e.data.type === 'CP_SELECTED') {
    if (_cpTargetId) {
      var el = document.getElementById(_cpTargetId);
      if (el) el.value = e.data.cpctNm || '';
      _cpTargetId = null;
    }
    if (_cpCallback) {
      try { _cpCallback(e.data); } catch (err) { console.error(err); }
      _cpCallback = null;
    }
  }

  if (e.data.type === 'PD_SELECTED') {
    if (_pdTargetId) {
      var el = document.getElementById(_pdTargetId);
      if (el) el.value = e.data.prodNm || '';
      _pdTargetId = null;
    }
    if (_pdCallback) {
      try { _pdCallback(e.data); } catch (err) { console.error(err); }
      _pdCallback = null;
    }
  }
});

/* ── 모달 중앙 정렬 ─────────────────────────────────────────── */
function centerModal(modalBg) {
  if (!modalBg) return;
  var m = modalBg.querySelector('.modal');
  if (!m) return;
  setTimeout(function() {
    var left = Math.max(0, (window.innerWidth  - m.offsetWidth)  / 2);
    var top  = Math.max(0, (window.innerHeight - m.offsetHeight) / 2);
    m.style.left = left + 'px';
    m.style.top  = top  + 'px';
  }, 0);
}

/* ── 모달 드래그 이동 ───────────────────────────────────────── */
function initModalDrag(bgId, headerId) {
  var bg  = document.getElementById(bgId);
  var hdr = document.getElementById(headerId);
  if (!bg || !hdr) return;
  var m = bg.querySelector('.modal');
  if (!m) return;
  var dragging = false, ox = 0, oy = 0;

  hdr.addEventListener('mousedown', function(e) {
    if (e.target.classList && e.target.classList.contains('close-btn')) return;
    dragging = true;
    ox = e.clientX - m.offsetLeft;
    oy = e.clientY - m.offsetTop;
    e.preventDefault();
  });
  document.addEventListener('mousemove', function(e) {
    if (!dragging) return;
    m.style.left = (e.clientX - ox) + 'px';
    m.style.top  = (e.clientY - oy) + 'px';
  });
  document.addEventListener('mouseup', function() { dragging = false; });
}

/* ── 업무규칙 모달 공통 오픈/클로즈 ─────────────────────────── */
function openRule() {
  var modal = document.getElementById('ruleModal');
  if (!modal) return;
  centerModal(modal);
  modal.classList.add('open');
}
function closeRule() {
  var modal = document.getElementById('ruleModal');
  if (modal) modal.classList.remove('open');
}

/* ── 가로 스크롤 동기화 ─────────────────────────────────────── */
function initHScroll(wrapId, scrollId, innerId, tableId) {
  var wrap   = document.getElementById(wrapId);
  var scroll = document.getElementById(scrollId);
  var inner  = document.getElementById(innerId);
  var table  = document.getElementById(tableId);
  if (!wrap || !scroll || !inner || !table) return;

  scroll.addEventListener('scroll', function() { wrap.scrollLeft = scroll.scrollLeft; });
  wrap.addEventListener('scroll',  function() { scroll.scrollLeft = wrap.scrollLeft; });
}

function syncHScroll(innerId, tableId) {
  var inner = document.getElementById(innerId);
  var table = document.getElementById(tableId);
  if (inner && table) inner.style.width = table.offsetWidth + 'px';
}

/* ── 페이지네이션 렌더 ──────────────────────────────────────── */
/* 사용: renderPagination('mainPaging', totalRows, pageSize, currentPage, 'goMainPage')
   - containerId: <div class="pagination"> 의 id
   - onClickFnName: 전역 함수명 (페이지 번호 클릭 시 호출)
*/
function renderPagination(containerId, total, size, current, onClickFnName) {
  var box = document.getElementById(containerId);
  if (!box) return;
  var totalPages = Math.max(1, Math.ceil(total / size));
  var html = '';
  var start = Math.max(1, current - 2);
  var end   = Math.min(totalPages, start + 4);
  if (end - start < 4) start = Math.max(1, end - 4);

  if (current > 1) {
    html += '<button class="page-btn" onclick="' + onClickFnName + '(' + (current - 1) + ')">&lt;</button>';
  }
  for (var p = start; p <= end; p++) {
    html += '<button class="page-btn ' + (p === current ? 'active' : '') +
            '" onclick="' + onClickFnName + '(' + p + ')">' + p + '</button>';
  }
  if (current < totalPages) {
    html += '<button class="page-btn" onclick="' + onClickFnName + '(' + (current + 1) + ')">&gt;</button>';
  }
  box.innerHTML = html;
}

/* 조회 건수 표시 (예: 1 ~ 17 of 17 rows) */
function renderRowCount(spanId, total, size, current) {
  var el = document.getElementById(spanId);
  if (!el) return;
  if (total === 0) { el.textContent = '0 rows'; return; }
  var from = (current - 1) * size + 1;
  var to   = Math.min(total, current * size);
  el.textContent = from + ' ~ ' + to + ' of ' + total + ' rows';
}

/* ── XSS 방지용 escape ──────────────────────────────────────── */
function esc(s) {
  if (s === null || s === undefined) return '';
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/* 숫자 천단위 콤마 */
function fmt(n) {
  if (n === null || n === undefined || n === '') return '';
  var num = Number(n);
  if (isNaN(num)) return String(n);
  return num.toLocaleString('ko-KR');
}
