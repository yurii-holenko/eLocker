import React from 'react';
import type { ChangeEvent } from 'react';

export interface FilterOption {
  value: string | number;
  label: string;
}

interface FilterSelectProps {
  name: string;
  label: string;
  // Text of the first option, which means "no filter".
  allLabel: string;
  value: string | number | null;
  options: FilterOption[];
}

const submitForm = (event: ChangeEvent<HTMLSelectElement>) => event.currentTarget.form?.requestSubmit();

// One labelled select of a FilterBar. With JavaScript, choosing an option
// applies the filter right away.
const FilterSelect = ({ name, label, allLabel, value, options }: FilterSelectProps) => (
  <div className="col-sm-6 col-lg">
    <label htmlFor={`filter-${name}`} className="form-label small fw-semibold text-body-secondary mb-1">
      {label}
    </label>
    <select
      id={`filter-${name}`}
      name={name}
      defaultValue={value ?? ''}
      className="form-select"
      onChange={submitForm}
    >
      <option value="">{allLabel}</option>
      {options.map((option) => (
        <option key={option.value} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
  </div>
);

export default FilterSelect;
