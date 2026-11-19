(function () {
  "use strict";

  const UNAVAILABLE_REGEX =
    /(?:^|[^\p{L}])(?:hỏng|hong|mất|mat|rách|rach|ướt|uot|bẩn|ban|thiếu|thieu|hư|ngừng|không bình thường|khong binh thuong|cần sửa|bảo trì)(?:$|[^\p{L}])/iu;

  function formatVnd(amount) {
    return new Intl.NumberFormat("vi-VN").format(amount);
  }

  function parseFine(inputEl) {
    if (!inputEl) return 0;
    const raw = (inputEl.value || "").trim();
    if (!/^[0-9]+$/.test(raw)) return 0;
    const val = Number(raw);
    return Number.isFinite(val) && val >= 0 ? val : 0;
  }

  // 1. Auto-clear alternate lookup input on gdTimBanDoc.jsp
  function initLookupInputs() {
    const cardInput = document.querySelector('input[name="inSothe"]');
    const codeInput = document.querySelector('input[name="inMaBanDoc"]');
    if (!cardInput || !codeInput) return;

    cardInput.addEventListener("input", function () {
      if (cardInput.value.trim().length > 0 && codeInput.value.length > 0) {
        codeInput.value = "";
      }
    });
    codeInput.addEventListener("input", function () {
      if (codeInput.value.trim().length > 0 && cardInput.value.length > 0) {
        cardInput.value = "";
      }
    });
  }

  // 2. Row selection, select-all, and counter on gdDSDangMuon.jsp
  function initLoanSelectionTable() {
    const table = document.getElementById("tblDangMuon");
    if (!table) return;

    const checkboxes = Array.from(table.querySelectorAll('input[type="checkbox"][name="chonTra"]'));
    const selectAll = document.getElementById("chonTatCa");
    const countEl = document.getElementById("selectedCount");

    function syncSelectionUI() {
      let checkedCount = 0;
      checkboxes.forEach(function (cb) {
        const row = cb.closest("tr");
        if (cb.checked) {
          checkedCount += 1;
          if (row) row.classList.add("is-selected");
        } else if (row) {
          row.classList.remove("is-selected");
        }
      });

      if (selectAll) {
        selectAll.checked = checkboxes.length > 0 && checkedCount === checkboxes.length;
        selectAll.indeterminate = checkedCount > 0 && checkedCount < checkboxes.length;
      }
      if (countEl) {
        countEl.textContent = "Đã chọn: " + checkedCount + " / " + checkboxes.length + " tài liệu";
      }
    }

    checkboxes.forEach(function (cb) {
      cb.addEventListener("change", syncSelectionUI);
      const row = cb.closest("tr");
      if (row) {
        row.setAttribute("data-selectable", "true");
        row.addEventListener("click", function (event) {
          if (event.target.closest("a, button, input, label")) return;
          cb.checked = !cb.checked;
          syncSelectionUI();
        });
      }
    });

    if (selectAll) {
      selectAll.addEventListener("change", function () {
        const targetState = selectAll.checked;
        checkboxes.forEach(function (cb) {
          cb.checked = targetState;
        });
        syncSelectionUI();
      });
    }

    syncSelectionUI();
  }

  // 3. Live fine calculation, overdue late-fine suggestion, and circulation forecast on gdChiTietTra.jsp
  function initReturnDetailsTable() {
    const table = document.getElementById("tblTaiLieuMuon");
    if (!table) return;

    const rows = Array.from(table.querySelectorAll("tbody tr[data-line-id]"));
    const totalEl = document.getElementById("liveTotalFine");
    const suggestBtn = document.getElementById("btnGoiYPhatCham");

    function updateDetailsSummary() {
      let total = 0;
      rows.forEach(function (row) {
        const id = row.getAttribute("data-line-id");
        const condInput = row.querySelector('[name="inTinhTrang.' + id + '"]');
        const damageInput = row.querySelector('input[name="inPhatHong.' + id + '"]');
        const lateInput = row.querySelector('input[name="inPhatCham.' + id + '"]');
        const lineTotalEl = row.querySelector("[data-line-total]");
        const badgeEl = row.querySelector("[data-circulation-badge]");

        const damage = parseFine(damageInput);
        const late = parseFine(lateInput);
        const lineTotal = damage + late;
        total += lineTotal;

        if (lineTotalEl) {
          lineTotalEl.textContent = formatVnd(lineTotal) + " đồng";
        }

        if (badgeEl) {
          const cond = condInput ? condInput.value.trim().replace(/\s+/g, " ") : "";
          const available = damage === 0 && cond.length > 0 && !UNAVAILABLE_REGEX.test(cond);
          badgeEl.className = "badge " + (available ? "badge-success" : "badge-warning");
          badgeEl.textContent = available ? "Có thể lưu thông" : "Ngừng lưu thông";
        }
      });

      if (totalEl) {
        totalEl.textContent = formatVnd(total) + " đồng";
      }
    }

    rows.forEach(function (row) {
      row.querySelectorAll("input, select").forEach(function (inputEl) {
        inputEl.addEventListener("input", updateDetailsSummary);
        inputEl.addEventListener("change", updateDetailsSummary);
      });
    });

    if (suggestBtn) {
      suggestBtn.addEventListener("click", function () {
        rows.forEach(function (row) {
          const id = row.getAttribute("data-line-id");
          const overdue = Number(row.getAttribute("data-overdue-days") || "0");
          if (overdue > 0) {
            const lateInput = row.querySelector('input[name="inPhatCham.' + id + '"]');
            if (lateInput) {
              lateInput.value = String(overdue * 5000);
            }
          }
        });
        updateDetailsSummary();
      });
    }

    updateDetailsSummary();
  }

  // 4. Double-submit protection for POST forms (respecting formnovalidate / submitter)
  function initDoubleSubmitGuard() {
    document.querySelectorAll('form[method="post"], form[method="POST"]').forEach(function (form) {
      form.addEventListener("submit", function (event) {
        if (form.dataset.submitted === "true") {
          event.preventDefault();
          return;
        }
        const submitter = event.submitter;
        const skipValidation = submitter && submitter.hasAttribute("formnovalidate");
        if (!skipValidation && typeof form.checkValidity === "function" && !form.checkValidity()) {
          return;
        }
        form.dataset.submitted = "true";
        form.classList.add("is-submitting");
        if (submitter && (submitter.tagName === "BUTTON" || submitter.tagName === "INPUT")) {
          window.setTimeout(function () {
            submitter.disabled = true;
          }, 0);
        }
      });
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    initLookupInputs();
    initLoanSelectionTable();
    initReturnDetailsTable();
    initDoubleSubmitGuard();
  });
})();
