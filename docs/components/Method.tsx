import styles from './Method.module.css'

type Props = {
  children: React.ReactNode
  name: string
  args?: [name: string, signature: string]
  returns?: string
}

export const Method = (props: Props) => {
  const { children, name, args, returns } = props

  const methodArgs = args?.map((arg, index) => {
    return (
      <span key={index}>
        <span className={styles.arg}>{arg[0]}</span>
        {index !== args.length - 1 ? ', ' : ''}
      </span>
    )
  })

  return (
    <div className="nextra-card nx-group nx-flex nx-flex-col nx-justify-start nx-overflow-hidden nx-rounded-lg nx-border nx-border-gray-200 nx-text-current nx-no-underline dark:nx-shadow-none hover:nx-shadow-gray-100 nx-shadow-gray-100 nx-bg-transparent nx-shadow-sm dark:nx-border-neutral-800 nx-mt-6">
      <div className="nx-p-4">
        <code>
          :{name}({methodArgs})
        </code>
      </div>
      {args && (
        <div>
          <div className={`${styles.bg} nx-p-4`}>
            <span className={styles.title}>Parameters</span>
          </div>
          <div className="nx-p-4">
            <table
              className={`${styles.table} nx-block nx-overflow-x-scroll nextra-scrollbar nx-mt-6 nx-p-0 first:nx-mt-0`}
            >
              <tbody>
                {args.map((arg, index) => {
                  const [key, type] = arg
                  return (
                    <tr key={index} className="nx-m-0 nx-p-0">
                      <td className="nx-m-0 nx-px-4 nx-py-2 dark:nx-border-gray-600">
                        <code>{key}</code>
                      </td>
                      <td className="nx-m-0 nx-px-4 nx-py-2 dark:nx-border-gray-600">
                        <code className={styles.type}>{type}</code>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}
      {returns && (
        <div>
          <div className={`${styles.bg} nx-p-4`}>
            <span className={styles.title}>Returns</span>
          </div>
          <div className="nx-p-4">
            → <code className={styles.returns}>{returns}</code>
          </div>
        </div>
      )}
      {children && (
        <div className="nx-p-4 nx-border-t nx-border-gray-200 dark:nx-border-neutral-800">
          {children}
        </div>
      )}
    </div>
  )
}
