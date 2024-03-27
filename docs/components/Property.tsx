import { jsonToLuaPretty } from './utils/json-to-lua'
import { Property as GrappProperty } from '@grapp/nextra-theme'

type Props = React.ComponentProps<typeof GrappProperty>

export const Property = (props: Props) => {
  return <GrappProperty {...props} parse={jsonToLuaPretty} />
}
