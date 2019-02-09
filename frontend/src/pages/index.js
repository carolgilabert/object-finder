import React from "react"

import Layout from "../components/layout"
import SEO from "../components/seo"

const IndexPage = () => (
  <Layout>
    <SEO title="Home" keywords={[`gatsby`, `application`, `react`]} />
    <h1>Hi people</h1>
    <p>I'm trying to get a static site in an S3 talking to an ALB that targets a lambda, to access the contents of another S3 bucket.</p>
    <p>Let's see what happens.</p>
  </Layout>
)

export default IndexPage
