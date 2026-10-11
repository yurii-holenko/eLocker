// Mirrors ApplicationController#pagination_props. Pages are fetched from
// Rails, so moving between them is following a link.
export interface PaginationData {
  page: number;
  totalPages: number;
  totalCount: number;
  previousPath: string | null;
  nextPath: string | null;
}
