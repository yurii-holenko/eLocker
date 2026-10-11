import React from 'react';

import { useTranslation } from '../../i18n/I18nContext';
import type { PaginationData } from '../../types/pagination';

const LINK_CLASS = 'btn btn-sm btn-outline-secondary';

// Previous / next links. Each page is a normal request to Rails.
const Pagination = ({ pagination }: { pagination: PaginationData }) => {
  const t = useTranslation();

  if (pagination.totalPages <= 1) return null;

  const link = (path: string | null, label: string) =>
    path ? (
      <a href={path} className={LINK_CLASS}>
        {label}
      </a>
    ) : (
      <span className={`${LINK_CLASS} disabled`} aria-disabled="true">
        {label}
      </span>
    );

  return (
    <nav className="d-flex align-items-center gap-3">
      {link(pagination.previousPath, t('table.previous'))}
      <span className="small text-body-secondary">
        {t('table.page_of', { page: pagination.page, total: pagination.totalPages })}
      </span>
      {link(pagination.nextPath, t('table.next'))}
    </nav>
  );
};

export default Pagination;
