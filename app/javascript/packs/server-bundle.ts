// Server entry: the same pages, rendered to HTML by Rails (`prerender: true`).
import ReactOnRails from 'react-on-rails';

import pages from '../pages';

ReactOnRails.register(pages);
