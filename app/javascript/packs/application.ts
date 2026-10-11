// Client entry: styles plus the pages React hydrates in the browser.
import 'bootstrap/dist/css/bootstrap.min.css';
import ReactOnRails from 'react-on-rails/client';

import pages from '../pages';

ReactOnRails.register(pages);
