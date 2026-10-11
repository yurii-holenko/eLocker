import React from 'react';

import type { Locker } from '../../types/locker';
import LockerActionButton from '../buttons/LockerActionButton';

// Rails decides which actions the current user may take on the locker.
const LockerActions = ({ locker }: { locker: Locker }) => (
  <div className="d-inline-flex gap-2">
    {locker.availableActions.map((kind) => (
      <LockerActionButton key={kind} locker={locker} kind={kind} />
    ))}
  </div>
);

export default LockerActions;
