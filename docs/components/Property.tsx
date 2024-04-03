import * as React from 'react';

import { Property as GrappProperty } from '@grapp/nextra-theme';

import { jsonToLuaPretty } from './utils/json-to-lua';

type Props = React.ComponentProps<typeof GrappProperty>;

export const Property = (props: Props) => {
  return <GrappProperty {...props} parse={jsonToLuaPretty} />;
};
