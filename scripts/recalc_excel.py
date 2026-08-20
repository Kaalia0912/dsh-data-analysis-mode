"""Recalculate every formula in an xlsx/xlsm and save cached values back, using
Microsoft Excel COM automation (Windows).

Drop-in alternative to the shipped `recalc.py` (LibreOffice-based) for machines
that have Microsoft Excel installed but no LibreOffice. Same CLI shape and the
same JSON contract:

    python recalc_excel.py output.xlsx [timeout_seconds]
    -> {"status": "success"|"errors_found", "total_formulas": N,
        "total_errors": M, "error_summary": {err_type: [cells...]}}

Exit codes: 0 on success AND on errors_found (matches the original contract —
check the JSON `status`, never the exit code); 1 when nothing was recalculated
(an `error` key is returned instead of `status`).
"""

import json
import os
import sys
import time

import win32com.client as win32
from openpyxl.utils import get_column_letter

ERROR_MARKERS = (
    "#DIV/0!", "#N/A", "#NAME?", "#NULL!", "#NUM!", "#REF!", "#VALUE!",
    "#SPILL!", "#CALC!", "#FIELD!", "#CONNECT!", "#BLOCKED!", "#UNKNOWN!",
)


def _is_error(value) -> str | None:
    """Return the error marker when `value` is an Excel error, else None."""
    if isinstance(value, str) and value.upper() in ERROR_MARKERS:
        return value.upper()
    # COM may surface errors as raw error objects; str() of those is the marker.
    if value is not None:
        try:
            text = str(value).strip().upper()
        except Exception:
            return None
        if text in ERROR_MARKERS:
            return text
    return None


def recalc(path: str, timeout_s: int = 60) -> dict:
    """Open the workbook in Excel, full-recalculate, save, return the report."""
    path = os.path.abspath(path)
    excel = win32.DispatchEx("Excel.Application")
    excel.Visible = False
    excel.DisplayAlerts = False
    try:
        excel.AskToUpdateLinks = False
        wb = excel.Workbooks.Open(path, UpdateLinks=0, ReadOnly=False)
        try:
            excel.CalculateFull()
            total_formulas = 0
            errors: dict[str, list[str]] = {}
            for ws in wb.Worksheets:
                used = ws.UsedRange
                if used is None:
                    continue
                # Formula scan first: openpyxl-written formulas are plain
                # strings, so the block read is safe and fast.
                try:
                    formulas = used.Formula
                except Exception:
                    continue
                formula_cells: list[tuple[int, int]] = []
                if isinstance(formulas, tuple):
                    for r in range(1, len(formulas) + 1):
                        f_row = formulas[r - 1]
                        if isinstance(f_row, tuple):
                            for c in range(1, len(f_row) + 1):
                                f = f_row[c - 1]
                                if isinstance(f, str) and f.startswith("="):
                                    formula_cells.append((r, c))
                        elif isinstance(f_row, str) and f_row.startswith("="):
                            formula_cells.append((r, 1))
                elif isinstance(formulas, str) and formulas.startswith("="):
                    formula_cells.append((1, 1))
                total_formulas += len(formula_cells)
                # Error check per formula cell, reading the display text
                # (.Text) so Excel error values come back as markers like
                # '#DIV/0!' instead of failing the COM value conversion.
                for r, c in formula_cells:
                    try:
                        marker = _is_error(used.Cells(r, c).Text)
                    except Exception:
                        marker = None
                    if marker is not None:
                        # COM `Address` evaluates eagerly to a string under
                        # pywin32, so build the cell reference locally instead.
                        cell_ref = f"{get_column_letter(c)}{r}"
                        errors.setdefault(marker, []).append(f"{ws.Name}!{cell_ref}")
            wb.Save()
            if errors:
                return {
                    "status": "errors_found",
                    "total_formulas": total_formulas,
                    "total_errors": sum(len(cells) for cells in errors.values()),
                    "error_summary": errors,
                }
            return {
                "status": "success",
                "total_formulas": total_formulas,
                "total_errors": 0,
                "error_summary": {},
            }
        finally:
            wb.Close(SaveChanges=False)
    finally:
        excel.Quit()
        del excel


def main() -> None:
    if len(sys.argv) < 2:
        print(json.dumps({"error": "usage: recalc_excel.py <xlsx> [timeout_seconds]"}))
        sys.exit(1)
    timeout_s = int(sys.argv[2]) if len(sys.argv) > 2 else 60
    try:
        report = recalc(sys.argv[1], timeout_s)
    except Exception as exc:  # COM startup/open failures -> nothing recalculated
        print(json.dumps({"error": str(exc)}))
        sys.exit(1)
    print(json.dumps(report, ensure_ascii=False))
    sys.exit(0)


if __name__ == "__main__":
    main()
