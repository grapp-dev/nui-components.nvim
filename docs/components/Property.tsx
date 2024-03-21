import styles from './Property.module.css'
import { jsonToLuaPretty } from './utils/json-to-lua'

type Props = {
  children: React.ReactNode
  name: string
  types: string[]
  defaultValue?: string | Record<string, any>
}

export const Property = (props: Props) => {
  const { children, types, defaultValue } = props

  return (
    <div className="nextra-card nx-group nx-flex nx-flex-col nx-justify-start nx-overflow-hidden nx-rounded-lg nx-border nx-border-gray-200 nx-text-current nx-no-underline dark:nx-shadow-none hover:nx-shadow-gray-100 nx-shadow-gray-100 nx-bg-transparent nx-shadow-sm dark:nx-border-neutral-800 nx-mt-6">
      {defaultValue && (
        <div>
          <div className={`${styles.bg} nx-p-4`}>
            <span className={styles.title}>Default value</span>
          </div>
          <div className="nx-p-4">
            {typeof defaultValue === 'object' ? (
              <pre>{jsonToLuaPretty(JSON.stringify(defaultValue), 1)}</pre>
            ) : (
              <code className={styles.default}>{defaultValue}</code>
            )}
          </div>
        </div>
      )}
      <div>
        <div className={`${styles.bg} nx-p-4`}>
          <span className={styles.title}>Type</span>
        </div>
        <div className="nx-p-4">
          <code className={styles.type}>{types.join(' | ')}</code>
        </div>
      </div>
      {children && (
        <div className="nx-p-4 nx-border-t nx-border-gray-200 dark:nx-border-neutral-800">
          {children}
        </div>
      )}
    </div>
  )
}
