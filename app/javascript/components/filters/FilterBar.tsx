import React from 'react';
import type { ReactNode } from 'react';

import { useTranslation } from '../../i18n/I18nContext';

interface FilterBarProps {
  // Where the form is sent; Rails does the searching and filtering.
  path: string;
  query: string;
  searchPlaceholder: string;
  // Whether any filter is set, which shows the reset link.
  active: boolean;
  // The FilterSelects of this bar.
  children?: ReactNode;
}

const SearchIcon = () => (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">
    <path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398l3.85 3.85a1 1 0 0 0 1.415-1.414zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0" />
  </svg>
);

// The filter above a table: a search box, any number of selects, and the
// apply / reset controls. It is a plain GET form, so a filtered table has its
// own address and works without JavaScript.
const FilterBar = ({ path, query, searchPlaceholder, active, children }: FilterBarProps) => {
  const t = useTranslation();

  return (
    <form action={path} method="get" className="card bg-body-tertiary border-0 mb-4">
      <div className="card-body">
        <div className="row g-3 align-items-end">
          <div className="col-12 col-lg-4">
            <label htmlFor="filter-q" className="form-label small fw-semibold text-body-secondary mb-1">
              {t('filter.search')}
            </label>
            <div className="input-group">
              <span className="input-group-text bg-body text-body-secondary">
                <SearchIcon />
              </span>
              <input
                id="filter-q"
                type="search"
                name="q"
                defaultValue={query}
                className="form-control border-start-0 ps-0"
                placeholder={searchPlaceholder}
              />
            </div>
          </div>

          {children}

          <div className="col-12 col-lg-auto d-flex gap-2">
            <button type="submit" className="btn btn-primary px-4">
              {t('filter.apply')}
            </button>
            {active && (
              <a href={path} className="btn btn-link text-decoration-none px-2">
                {t('filter.reset')}
              </a>
            )}
          </div>
        </div>
      </div>
    </form>
  );
};

export default FilterBar;
