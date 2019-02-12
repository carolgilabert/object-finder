import React from "react"
import axios from "axios"

import Layout from "../components/layout"
import SEO from "../components/seo"

class IndexPage extends React.Component {
  state = { keys: [] }

  componentDidMount() {
    this.fetchObjectKeys()
  }

  fetchObjectKeys() {
    const urlALB = 'http://object-finder-97329035.eu-west-1.elb.amazonaws.com';
    axios.get(urlALB)
      .then(response => {
        this.setState({
          keys: response.data.Contents
        })
      })
      .catch(error => console.error(error));
  }

  render() {
    return (
      <Layout>
        <SEO title="Home" keywords={[`gatsby`, `application`, `react`]} />
        <h1>Hi people</h1>
        <p>I'm trying to get a static site in an S3 talking to an ALB that targets a lambda, to access the contents of another S3 bucket.</p>
        <p>Let's see what happens.</p>
        <div>
          <h2>Object Keys</h2>
          <ul>{this.state.keys.map(el => <li key={el.Key}> {el.Key} </li>)}</ul>
        </div>
      </Layout>
    );
  }
}

export default IndexPage
