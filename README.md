# E-Commerce Customer Segmentation Analysis 📊
> **Tools used:** SQL (PostgreSQL), Python (Pandas, Scikit-Learn), Seaborn

##  Project Overview
The goal of this project was to analyze customer behavior for a UK-based online retailer and group customers into distinct segments using the **RFM (Recency, Frequency, Monetary)** framework. This allows the marketing team to move from a "mass-marketing" approach to highly targeted, data-driven strategies.

##  Key Results
Using **K-Means Clustering**, I identified 4 distinct customer segments:
- **Champions:** High spenders, frequent buyers, and most recent shoppers.
- **Loyalists:** Consistent shoppers with good spend but lower frequency than Champions.
- **New/Recent:** High recency but low frequency; potential for growth.
- **At-Risk:** Haven't shopped in 6+ months; high risk of churn.

## 📈 Visualizations

### 1. Optimal Cluster Selection (Elbow Method)
Used to mathematically determine the optimal number of customer segments (k=4).

![Elbow Plot](https://github.com/h0otism/Customer-Segmentation-Retail-Analysis/blob/main/visuals:/elbow_plot.png?raw=true)

### 2. Customer Segment Behavior (Snake Plot)
This plot identifies how our 'Champions' differ from 'At-Risk' customers across standardized RFM values.

![Snake Plot](https://github.com/h0otism/Customer-Segmentation-Retail-Analysis/blob/main/visuals:/snake_plot.png?raw=true)

### 3. Attribute Importance Heatmap
Identifies which metrics (Recency, Frequency, or Monetary) are the defining traits of each cluster.

![Cluster Heatmap](https://github.com/h0otism/Customer-Segmentation-Retail-Analysis/blob/main/visuals:/cluster_heatmap.png?raw=true)

##  Technical Workflow
1. **Data Engineering (SQL):** - Cleaned raw transaction logs (500k+ rows).
   - Handled missing Customer IDs and filtered out returns/cancellations.
   - Built a custom query to aggregate data into RFM metrics per customer.
2. **Data Science (Python):**
   - Performed **Log Transformation** to handle right-skewed data.
   - Scaled features using **StandardScaler**.
   - Implemented **K-Means Clustering** and interpreted results.

##  Business Recommendations
- **Champions:** Invite to a VIP Loyalty program.
- **New Shoppers:** Send a "second-purchase" discount code.
- **At-Risk:** Launch a re-engagement email campaign with a "We Miss You" offer.

---
**Author:** Minh Nguyen  
**Contact:** https://www.linkedin.com/in/minhng224/ 
