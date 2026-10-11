import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import type { LockerActionRecordKind } from '../../types/lockerAction';
import FilterBar from '../filters/FilterBar';
import FilterSelect from '../filters/FilterSelect';

interface Option {
  id: number;
  name: string;
}

// Mirrors the `filter` prop built in LockerActionsController#index.
export interface ActionLogFilterData {
  path: string;
  query: string;
  lockerId: number | null;
  lockers: Option[];
  kind: LockerActionRecordKind | null;
  kinds: LockerActionRecordKind[];
  userId: number | null;
  users: Option[];
}

// Search plus selects for locker, action and user.
const ActionLogFilter = ({ filter }: { filter: ActionLogFilterData }) => {
  const t = useTranslation();

  return (
    <FilterBar
      path={filter.path}
      query={filter.query}
      searchPlaceholder={t('history.filter.search_placeholder')}
      active={filter.query !== '' || filter.lockerId !== null || filter.kind !== null || filter.userId !== null}
    >
      <FilterSelect
        name="locker_id"
        label={t('history.filter.locker')}
        allLabel={t('history.filter.all_lockers')}
        value={filter.lockerId}
        options={filter.lockers.map((locker) => ({ value: locker.id, label: locker.name }))}
      />
      <FilterSelect
        name="kind"
        label={t('history.filter.kind')}
        allLabel={t('history.filter.all_kinds')}
        value={filter.kind}
        options={filter.kinds.map((kind) => ({ value: kind, label: t(`history.kinds.${kind}`) }))}
      />
      <FilterSelect
        name="user_id"
        label={t('history.filter.user')}
        allLabel={t('history.filter.all_users')}
        value={filter.userId}
        options={filter.users.map((user) => ({ value: user.id, label: user.name }))}
      />
    </FilterBar>
  );
};

export default ActionLogFilter;
