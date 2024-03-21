import { useData } from 'nextra/data'
// import { Benefits } from './Benefits';
import { Features } from './Features'
import styles from './Homepage.module.css'
import { Hero } from './Hero'

export const Homepage = () => {
  return (
    <>
      <Hero />
      <div className={styles.content}>
        <div className={styles.preview}>
          <img src="/gifs/hero.gif" />
        </div>
        <Features />
      </div>
    </>
  )
}
