import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import type { LockerActionRecord } from '../../types/lockerAction';

// A list of recorded locker actions, newest first as sent by Rails.
const ActionsTable = ({ actions }: { actions: LockerActionRecord[] }) => {
  const t = useTranslation();

  if (actions.length === 0) {
    return <p className="text-body-secondary">{t('history.empty')}</p>;
  }

  return (
    <table className="table table-sm align-middle">
      <thead>
        <tr>
          <th>{t('history.columns.time')}</th>
          <th>{t('history.columns.action')}</th>
          <th>{t('history.columns.user')}</th>
        </tr>
      </thead>
      <tbody>
        {actions.map((action) => (
          <tr key={action.id}>
            <td className="text-nowrap">{action.performedAt}</td>
            <td>{t(`history.kinds.${action.kind}`)}</td>
            <td>{action.user ?? <span className="text-body-secondary">{t('history.system')}</span>}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default ActionsTable;
