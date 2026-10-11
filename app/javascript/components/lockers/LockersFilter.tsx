import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import type { LockerState } from '../../types/locker';
import FilterBar from '../filters/FilterBar';
import FilterSelect from '../filters/FilterSelect';

// Mirrors the `filter` prop built in LockersController#index.
export interface LockersFilterData {
  path: string;
  query: string;
  state: LockerState | null;
  states: LockerState[];
  teamId: number | null;
  // Teams of the lockers the user may see: one for an employee.
  teams: { id: number; name: string }[];
}

// Search plus selects for state and, when there is a choice, team.
const LockersFilter = ({ filter }: { filter: LockersFilterData }) => {
  const t = useTranslation();

  return (
    <FilterBar
      path={filter.path}
      query={filter.query}
      searchPlaceholder={t('lockers.filter.search_placeholder')}
      active={filter.query !== '' || filter.state !== null || filter.teamId !== null}
    >
      <FilterSelect
        name="state"
        label={t('lockers.filter.state')}
        allLabel={t('lockers.filter.all_states')}
        value={filter.state}
        options={filter.states.map((state) => ({ value: state, label: t(`lockers.states.${state}`) }))}
      />
      {filter.teams.length > 1 && (
        <FilterSelect
          name="team_id"
          label={t('lockers.filter.team')}
          allLabel={t('lockers.filter.all_teams')}
          value={filter.teamId}
          options={filter.teams.map((team) => ({ value: team.id, label: team.name }))}
        />
      )}
    </FilterBar>
  );
};

export default LockersFilter;
