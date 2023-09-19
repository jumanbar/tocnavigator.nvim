# Inicio ----
library(dplyr)

unaVariable <- seq(-10, 10, .01)

## Print =======
print(distinct(iris, Species))

papa <- function(x) {
  x ^ 6 - 2
}

plot(log(papa(unaVariable)))


# The query =====
# (left_assignment
#   name: (identifier) @fun
#   value: (function_definition) @def)
