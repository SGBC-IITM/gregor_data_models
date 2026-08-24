(function () {
  function findSelect(name) {
    return document.querySelector('select[name="' + name + '"]');
  }

  async function loadColumns(tableName, columnSelect, selectedValue) {
    columnSelect.innerHTML = '<option value="">---------</option>';
    if (!tableName) {
      return;
    }

    const response = await fetch('/admin/key-values-columns/?table_name=' + encodeURIComponent(tableName), {
      credentials: 'same-origin',
    });
    const payload = await response.json();
    const columns = payload.columns || [];

    for (const column of columns) {
      const option = document.createElement('option');
      option.value = column;
      option.textContent = column;
      if (column === selectedValue) {
        option.selected = true;
      }
      columnSelect.appendChild(option);
    }
  }

  function init() {
    const tableSelect = findSelect('table_name');
    const columnSelect = findSelect('column_name');
    if (!tableSelect || !columnSelect) {
      return;
    }

    const initialColumn = columnSelect.value;
    loadColumns(tableSelect.value, columnSelect, initialColumn);

    tableSelect.addEventListener('change', function () {
      loadColumns(tableSelect.value, columnSelect, '');
    });
  }

  document.addEventListener('DOMContentLoaded', init);
})();
