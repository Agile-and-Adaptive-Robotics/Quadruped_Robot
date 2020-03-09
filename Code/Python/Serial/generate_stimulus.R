library('data.table') # data.table and fast fwrite
max_stim = 450

# excites each of 6 muscles in sequence for an equal amount of time
alternating.stim = function() {
    length = 10000
    x = data.table()
    x = cbind(x, 1:length)
    for (i in 0:5) {
        y = rep(0, length)

        y[floor(seq(from=(length/6)*i, length.out=length/6))] = max_stim
        x = cbind(x, y)
    }
    x
}

# muscles takes a vector of values 1-6 corresponding to muscle ids
# 43, 44, 39, 40, 41, 42
constant.stim = function(muscles) {
    length = 500
    x = data.table()
    x = cbind(x, 1:length)
    for (i in 0:5) {
        if ((i+1) %in% muscles) {    # note the 'in', you can give a single value or a vector
            y = rep(max_stim, length)
        }
        else {
            y = rep(0, length)
        }

        x = cbind(x, y)
    }
    x
}

#names(d) = c('n','a','b','c','d','e','f')

#fwrite(single.stim(1), 'my_stim.csv')
