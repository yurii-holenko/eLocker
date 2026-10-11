import React from 'react';

import ActionLogFilter from '../components/actions/ActionLogFilter';
import type { ActionLogFilterData } from '../components/actions/ActionLogFilter';
import ActionsTable from '../components/actions/ActionsTable';
import { useTranslation } from '../i18n/I18nContext';
import type { LockerActionRecord } from '../types/lockerAction';
import type { PaginationData } from '../types/pagination';

export interface ActionLogPageProps {
  actions: LockerActionRecord[];
  pagination: PaginationData;
  filter: ActionLogFilterData;
}

const ActionLogPage = ({ actions, pagination, filter }: ActionLogPageProps) => {
  const t = useTranslation();

  return (
    <>
      <div className="d-flex align-items-baseline justify-content-between mb-3">
        <h1 className="h3 mb-0">{t('history.log_title')}</h1>
        <span className="text-body-secondary small">{t('history.found', { count: pagination.totalCount })}</span>
      </div>

      <ActionLogFilter filter={filter} />
      <ActionsTable actions={actions} pagination={pagination} showLocker />
    </>
  );
};

export default ActionLogPage;
