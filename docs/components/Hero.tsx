import Link from 'next/link'
import styles from './Hero.module.css'

export const Hero = () => {
  return (
    <div className={styles.root}>
      <div className={styles.content}>
        <h1 className={styles.headline}>
          A set of tools for creating <br className="sm:hidden" />
          <br className="hidden sm:block" />
          user interfaces in Neovim
        </h1>
        <p className={styles.subtitle}>
          NuiComponents is a library built on top of{' '}
          <a
            href="https://github.com/MunifTanjim/nui.nvim"
            target="_blank"
            rel="noopener noreferrer"
            className="nx-text-primary-600 nx-underline nx-decoration-from-font [text-underline-position:from-font]"
          >
            nui.nvim
          </a>
          ,
          <br />
          it aims to make UI development in Neovim more accessible, intuitive, and enjoyable.
        </p>
        <div className={styles.actions}>
          <Link className={`${styles.button} ${styles.buttonFull}`} href="/docs/getting-started">
            Get started <span>→</span>
          </Link>
        </div>
      </div>
    </div>
  )
}
