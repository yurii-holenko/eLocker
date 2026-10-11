import React from 'react';
import { createColumnHelper, tableFeatures, useTable } from '@tanstack/react-table';
import type { ColumnDef, RowData } from '@tanstack/react-table';

import type { PaginationData } from '../../types/pagination';
import Pagination from './Pagination';

// Only TanStack Table's core is used: it turns column definitions and rows
// into header and cell models. Paging and filtering happen in Rails, so the
// rows passed in are already the page to show.
const features = tableFeatures({});

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type DataTableColumn<TRow extends RowData> = ColumnDef<typeof features, TRow, any>;

// Column builder for a row type: columnHelper<Locker>().accessor('name', ...)
export const columnHelper = <TRow extends RowData>() => createColumnHelper<typeof features, TRow>();

interface DataTableProps<TRow extends RowData> {
  // Must be defined once, outside of components: TanStack Table rebuilds its
  // models whenever it gets a new columns array.
  columns: DataTableColumn<TRow>[];
  rows: TRow[];
  emptyText: string;
  pagination?: PaginationData;
  className?: string;
}

const DataTable = <TRow extends RowData>({
  columns,
  rows,
  emptyText,
  pagination,
  className = 'table align-middle',
}: DataTableProps<TRow>) => {
  const table = useTable({ features, columns, data: rows });

  if (rows.length === 0) {
    return <p className="text-body-secondary">{emptyText}</p>;
  }

  return (
    <>
      <table className={className}>
        <thead>
          {table.getHeaderGroups().map((group) => (
            <tr key={group.id}>
              {group.headers.map((header) => (
                <th key={header.id}>{header.isPlaceholder ? null : <table.FlexRender header={header} />}</th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map((row) => (
            <tr key={row.id}>
              {row.getAllCells().map((cell) => (
                <td key={cell.id}>
                  <table.FlexRender cell={cell} />
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>

      {pagination && <Pagination pagination={pagination} />}
    </>
  );
};

export default DataTable;
