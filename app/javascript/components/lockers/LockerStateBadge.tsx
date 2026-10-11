import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import type { Locker, LockerState } from '../../types/locker';

const STATE_CLASS: Record<LockerState, string> = {
  open: 'text-bg-warning',
  closed: 'text-bg-success',
  blocked: 'text-bg-danger',
};

const LockerStateBadge = ({ locker }: { locker: Locker }) => {
  const t = useTranslation();
  const minutesLeft = locker.blockedMinutesLeft ?? 0;

  return (
    <>
      <span className={`badge ${STATE_CLASS[locker.state]}`}>{t(`lockers.states.${locker.state}`)}</span>
      {minutesLeft > 0 && (
        <small className="text-body-secondary ms-2">
          {t('lockers.blocked_minutes_left', { minutes: minutesLeft })}
        </small>
      )}
    </>
  );
};

export default LockerStateBadge;
