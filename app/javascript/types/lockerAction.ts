// Mirrors LockerActionSerializer and LockerAction::KINDS.
export type LockerActionRecordKind = 'open' | 'close' | 'fail_attempt' | 'block' | 'unblock';

export interface LockerActionRecord {
  id: number;
  kind: LockerActionRecordKind;
  // null when the system did it, e.g. the timed unblock.
  user: string | null;
  performedAt: string;
}
