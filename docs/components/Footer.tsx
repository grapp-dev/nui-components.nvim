import { Link } from 'nextra-theme-docs'
import styles from './Footer.module.css'

export const Footer = () => {
  return (
    <div className={`${styles.root} lg:flex lg:flex-row-reverse`}>
      <div className={`${styles.columns} lg:w-3/4`}>
        <section>
          <h4>FAQ</h4>
          <ul>
            <li>
              <Link href="/docs#what-is-nuicomponents">What is NuiComponents?</Link>
            </li>
            <li>
              <Link href="/docs#key-features">Key Features</Link>
            </li>
            <li>
              <Link href="/about">About Grapp.Dev</Link>
            </li>
          </ul>
        </section>
        <section>
          <h4>Guides</h4>
          <ul>
            <li>
              <Link href="/docs/getting-started#your-first-ui-implementation">
                Your first UI implementation
              </Link>
            </li>
            <li>
              <Link href="/docs/signal#usage-example">Discover Signal API</Link>
            </li>
            <li>
              <Link href="/docs/component#create-a-new-component">Create a new component</Link>
            </li>
          </ul>
        </section>
        <section>
          <h4>Grapp.Dev</h4>
          <ul>
            <li>
              <Link href="https://github.com/grapp-dev/nui-components.nvim">GitHub ↗</Link>
            </li>
            <li>
              <Link href="https://discord.gg/Rj2V3keVS4">Discord ↗</Link>
            </li>
            <li>
              <Link href="https://github.com/grapp-dev/nui-components.nvim/discussions">
                Discussions ↗
              </Link>
            </li>
            <li>
              <Link href="https://github.com/sponsors/mobily">Sponsor ↗</Link>
            </li>
          </ul>
        </section>
      </div>
      <div className="lg:w-1/4">
        © {new Date().getFullYear()} <Link href="/">Grapp.Dev</Link>
      </div>
    </div>
  )
}
