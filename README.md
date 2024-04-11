This application empowers you to delve into the world of probability distributions within the Flutter framework. It equips you with essential tools to quantify the differences and similarities between two probability distributions. Here's a breakdown of the key distance metrics you can explore:

* Kullback-Leibler Divergence (KLD): Imagine you have a reference distribution, representing the "true" probabilities for a scenario. KLD tells you how much information you would lose (on average) if you used an approximate distribution instead of the true one. In simpler terms, it measures the extra surprise you encounter when using an inaccurate model compared to the actual distribution.

* Bhattacharyya Distance: This metric takes a more symmetrical approach, providing a measure of similarity between two distributions. A lower Bhattacharyya distance indicates greater resemblance between the distributions.

* Cramer Distance: This metric focuses on the maximum difference between the cumulative distribution functions (CDFs) of two distributions. The CDF tells you the probability that a random variable will be less than or equal to a certain value. So, Cramer distance essentially highlights the largest discrepancy between the probabilities of events occurring under the two distributions.
