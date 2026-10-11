import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import type { Locker, LockerActionKind } from '../../types/locker';
import PostButton from './PostButton';

const KIND_CLASS: Record<LockerActionKind, string> = {
  open: 'btn-outline-primary',
  close: 'btn-outline-secondary',
  fail_attempt: 'btn-outline-danger',
};

interface LockerActionButtonProps {
  locker: Locker;
  kind: LockerActionKind;
}

// Fires one action (open, close, fail_attempt) on a locker.
const LockerActionButton = ({ locker, kind }: LockerActionButtonProps) => {
  const t = useTranslation();

  return (
    <PostButton action={locker.actionsPath} params={{ kind }} className={`btn btn-sm ${KIND_CLASS[kind]}`}>
      {t(`lockers.actions.${kind}`)}
    </PostButton>
  );
};

export default LockerActionButton;
