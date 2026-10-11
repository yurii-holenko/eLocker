import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import type { LockerDetails as LockerDetailsData } from '../../types/locker';
import LockerActions from './LockerActions';
import LockerStateBadge from './LockerStateBadge';

// The locker's facts, current state and the actions the viewer may take.
const LockerDetails = ({ locker }: { locker: LockerDetailsData }) => {
  const t = useTranslation();

  return (
    <div className="card mb-4">
      <div className="card-body">
        <dl className="row mb-3">
          <dt className="col-sm-4">{t('lockers.details.location')}</dt>
          <dd className="col-sm-8">{locker.location}</dd>

          <dt className="col-sm-4">{t('lockers.details.company')}</dt>
          <dd className="col-sm-8">{locker.company}</dd>

          <dt className="col-sm-4">{t('lockers.details.team')}</dt>
          <dd className="col-sm-8">{locker.team}</dd>

          <dt className="col-sm-4">{t('lockers.details.state')}</dt>
          <dd className="col-sm-8">
            <LockerStateBadge locker={locker} />
          </dd>

          {locker.attemptsLeft !== null && (
            <>
              <dt className="col-sm-4">{t('lockers.details.attempts_left')}</dt>
              <dd className="col-sm-8">
                {t('lockers.details.attempts_left_value', {
                  left: locker.attemptsLeft,
                  max: locker.maxFailedAttempts,
                })}
              </dd>
            </>
          )}
        </dl>

        <LockerActions locker={locker} />
      </div>
    </div>
  );
};

export default LockerDetails;
