// Mirrors the JSON built by LockerSerializer (app/serializers/locker_serializer.rb).
export type LockerState = 'closed' | 'open' | 'blocked';

// Mirrors Locker::USER_EVENTS.
export type LockerActionKind = 'open' | 'close' | 'fail_attempt';

export interface Locker {
  id: number;
  name: string;
  location: string;
  state: LockerState;
  blockedMinutesLeft: number | null;
  team: string;
  company: string;
  availableActions: LockerActionKind[];
  actionsPath: string;
}
