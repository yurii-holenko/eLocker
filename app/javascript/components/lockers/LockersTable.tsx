import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import type { Locker } from '../../types/locker';
import LockerActions from './LockerActions';
import LockerStateBadge from './LockerStateBadge';

const LockersTable = ({ lockers }: { lockers: Locker[] }) => {
  const t = useTranslation();

  return (
    <table className="table table-hover align-middle">
      <thead>
        <tr>
          <th>{t('lockers.columns.name')}</th>
          <th>{t('lockers.columns.location')}</th>
          <th>{t('lockers.columns.company')}</th>
          <th>{t('lockers.columns.team')}</th>
          <th>{t('lockers.columns.state')}</th>
          <th className="text-end">{t('lockers.columns.action')}</th>
        </tr>
      </thead>
      <tbody>
        {lockers.map((locker) => (
          <tr key={locker.id}>
            <td className="fw-semibold">
              <a href={locker.path}>{locker.name}</a>
            </td>
            <td>{locker.location}</td>
            <td>{locker.company}</td>
            <td>{locker.team}</td>
            <td>
              <LockerStateBadge locker={locker} />
            </td>
            <td className="text-end">
              <LockerActions locker={locker} />
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default LockersTable;
