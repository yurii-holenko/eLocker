// Every page a Rails view can render with `react_component`. Both bundle
// entries register this same list, so a page is added in one place.
import withProviders from '../providers/withProviders';
import LockersListPage from './LockersListPage';

export default {
  LockersListPage: withProviders(LockersListPage),
};
