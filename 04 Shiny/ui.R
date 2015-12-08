require(shiny)
require(shinydashboard)
require(leaflet)

dashboardPage(
  dashboardHeader(
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Bar Chart", tabName = "barchart", icon = icon("th")),
      menuItem("Scatterplot1", tabName = "scatter1", icon = icon("th")),
      menuItem("Scatterplot2", tabName = "scatter2", icon = icon("th")),
      menuItem("Crosstab", tabName = "crosstab", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "barchart",
              plotOutput("distbar")
      ),
      tabItem(tabName = "scatter1",
              plotOutput("distcat1")
      ),
      tabItem(tabName = "scatter2",
              plotOutput("distcat2")
      ),
      tabItem(tabName = "crosstab",
              plotOutput("distcross")
      )
    )
  )
)