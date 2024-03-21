import NuiComponentsLogo from './svg/nui-components-logo.svg'
import styles from './Logo.module.css'

export const Logo = () => {
  return (
    <div className={styles.root}>
      <NuiComponentsLogo className={styles.logo} />
      <span className={styles.title}>Nui.Components</span>
    </div>
  )
}
