from agents.trader.price_trader import *
from classes.graph.a_graph import Graph

class Full_Graph(Graph):
    

    def add_to_graph(self, price_station, pool):
        Graph.add_to_graph(self, price_station, pool)

    def plot(self):
        Graph.plotGraph1(self, 'images/full_graph.png')
        self.plotGraph2()

    def plotGraph2(self):
        return