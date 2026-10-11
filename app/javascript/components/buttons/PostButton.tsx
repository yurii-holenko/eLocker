import React from 'react';
import type { ReactNode } from 'react';

import { useCsrfToken } from '../../providers/CsrfContext';

interface PostButtonProps {
  action: string;
  params?: Record<string, string>;
  className?: string;
  children: ReactNode;
}

// A button that submits a plain form POST to Rails. `params` become hidden
// fields; Rails handles the request and redirects, so no fetch is involved.
const PostButton = ({
  action,
  params = {},
  className = 'btn btn-sm btn-outline-primary',
  children,
}: PostButtonProps) => {
  const csrfToken = useCsrfToken();

  return (
    <form action={action} method="post" className="d-inline">
      <input type="hidden" name="authenticity_token" value={csrfToken} />
      {Object.entries(params).map(([name, value]) => (
        <input key={name} type="hidden" name={name} value={value} />
      ))}
      <button type="submit" className={className}>
        {children}
      </button>
    </form>
  );
};

export default PostButton;
