import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import T from '../../i18n/T';
import type { Locker } from '../../types/locker';
import type { PaginationData } from '../../types/pagination';
import DataTable, { columnHelper } from '../tables/DataTable';
import LockerActions from './LockerActions';
import LockerStateBadge from './LockerStateBadge';

const column = columnHelper<Locker>();

const COLUMNS = column.columns([
  column.accessor('name', {
    header: () => <T id="lockers.columns.name" />,
    cell: (cell) => (
      <a href={cell.row.original.path} className="fw-semibold">
        {cell.getValue()}
      </a>
    ),
  }),
  column.accessor('location', { header: () => <T id="lockers.columns.location" /> }),
  column.accessor('company', { header: () => <T id="lockers.columns.company" /> }),
  column.accessor('team', { header: () => <T id="lockers.columns.team" /> }),
  column.accessor('state', {
    header: () => <T id="lockers.columns.state" />,
    cell: (cell) => <LockerStateBadge locker={cell.row.original} />,
  }),
  column.display({
    id: 'actions',
    header: () => <T id="lockers.columns.action" />,
    cell: (cell) => <LockerActions locker={cell.row.original} />,
  }),
]);

interface LockersTableProps {
  lockers: Locker[];
  pagination: PaginationData;
}

// The lockers the user may see, one page as sent by Rails.
const LockersTable = ({ lockers, pagination }: LockersTableProps) => {
  const t = useTranslation();

  return (
    <DataTable
      columns={COLUMNS}
      rows={lockers}
      emptyText={t('lockers.empty')}
      pagination={pagination}
      className="table table-hover align-middle"
    />
  );
};

export default LockersTable;
