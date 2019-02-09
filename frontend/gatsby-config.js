module.exports = {
  siteMetadata: {
    title: `Object Finder`,
    description: `Proving out a static-site -> ALB -> lambda -> s3 flow to retrieve objects and display on a UI.`,
    author: `Carolina Gilabert`,
  },
  plugins: [
    `gatsby-plugin-react-helmet`,
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        name: `images`,
        path: `${__dirname}/src/images`,
      },
    },
    `gatsby-transformer-sharp`,
    `gatsby-plugin-sharp`
  ],
}
