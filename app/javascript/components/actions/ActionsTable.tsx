import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import T from '../../i18n/T';
import type { LockerActionRecord } from '../../types/lockerAction';
import type { PaginationData } from '../../types/pagination';
import DataTable, { columnHelper } from '../tables/DataTable';

const column = columnHelper<LockerActionRecord>();

const timeColumn = column.accessor('performedAt', {
  header: () => <T id="history.columns.time" />,
  cell: (cell) => <span className="text-nowrap">{cell.getValue()}</span>,
});

const lockerColumn = column.accessor('locker', {
  header: () => <T id="history.columns.locker" />,
  cell: (cell) => <a href={cell.row.original.lockerPath}>{cell.getValue()}</a>,
});

const kindColumn = column.accessor('kind', {
  header: () => <T id="history.columns.action" />,
  cell: (cell) => <T id={`history.kinds.${cell.getValue()}`} />,
});

const userColumn = column.accessor('user', {
  header: () => <T id="history.columns.user" />,
  // No user means the system did it, e.g. the timed unblock.
  cell: (cell) =>
    cell.getValue() ?? (
      <span className="text-body-secondary">
        <T id="history.system" />
      </span>
    ),
});

// One locker's history does not need to repeat the locker in every row.
const COLUMNS = column.columns([timeColumn, kindColumn, userColumn]);
const COLUMNS_WITH_LOCKER = column.columns([timeColumn, lockerColumn, kindColumn, userColumn]);

interface ActionsTableProps {
  actions: LockerActionRecord[];
  pagination: PaginationData;
  showLocker?: boolean;
}

// Recorded locker actions, newest first, one page as sent by Rails.
const ActionsTable = ({ actions, pagination, showLocker = false }: ActionsTableProps) => {
  const t = useTranslation();

  return (
    <DataTable
      columns={showLocker ? COLUMNS_WITH_LOCKER : COLUMNS}
      rows={actions}
      emptyText={t('history.empty')}
      pagination={pagination}
      className="table table-sm align-middle"
    />
  );
};

export default ActionsTable;
