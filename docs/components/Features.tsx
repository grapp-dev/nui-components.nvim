import { ReactNode } from 'react'
import styles from './Features.module.css'

export const Features = () => {
  return (
    <div className={styles.root}>
      <h3>Key Features</h3>
      <ul className={styles.features}>
        <Feature
          title="Reactive UI"
          description="The library automatically handles UI updates based on input and events received."
        />
        <Feature
          title="Flexbox"
          description="NuiComponents supports a simple flexbox layout system, which provides a more flexible way to layout UIs."
        />
        <Feature
          title="State Management"
          description="The library provides a state management system that allows managing data and UI state with ease."
        />

        <Feature
          title="Extensibility"
          description="Create your custom components by using Component API."
        />
        <Feature
          title="Reusability"
          description="Reuse components between different parts of UI, reduce the amount of code you need to write."
        />
      </ul>
    </div>
  )
}

type FeatureProps = {
  title: string
  description: ReactNode
  icon?: ReactNode
}

function Feature(props: FeatureProps) {
  const { title, description, icon } = props

  return (
    <li>
      <strong>{title}</strong> {description}
    </li>
  )
}
