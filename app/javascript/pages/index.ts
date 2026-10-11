// Everything a Rails view can render with `react_component`. Both bundle
// entries register this same list, so a component is added in one place.
import FlashToasts from '../components/feedback/FlashToasts';
import withProviders from '../providers/withProviders';
import ActionLogPage from './ActionLogPage';
import LockerPage from './LockerPage';
import LockersListPage from './LockersListPage';

export default {
  // Rendered by the layout on every page that has a flash message.
  FlashToasts,
  ActionLogPage: withProviders(ActionLogPage),
  LockerPage: withProviders(LockerPage),
  LockersListPage: withProviders(LockersListPage),
};
