import codecademylib
import pandas as pd
#saving the dataframe as ad_clicks
ad_clicks = pd.read_csv('ad_clicks.csv')

#creating a vairable to count the most views from an utm source
most_view = ad_clicks.groupby('utm_source').user_id.count().reset_index()
print(most_view)

#Created a new column called is_click, which is True if ad_click_timestamp is not null and False otherwise.
ad_clicks['is_click'] = ~ad_clicks\
   .ad_click_timestamp.isnull()
#This is to figure out the percent of people who clicked on ads from each utm_source
clicks_by_source = ad_clicks.groupby(['utm_source', 'is_click']).user_id.count().reset_index()

#converting clicks by source variable to pivot
clicks_pivot = clicks_by_source.pivot(
  columns='is_click',
  index='utm_source',
  values='user_id'
).reset_index()

#adding a new column to pivot table
clicks_pivot['percent_clicked'] =  \
   clicks_pivot[True] / \
   (clicks_pivot[True] + 
    clicks_pivot[False])

#checking to see whether people were shown the same amount of ads
ex = ad_clicks.groupby(['experimental_group', 'is_click']).user_id.count().reset_index()

# created a pivot table to see if a greater percentage of users clicked on which AD
ex_pivot = ex.pivot(
  columns='experimental_group',
  index='is_click',
  values='user_id'
).reset_index()

# dataframe for each click result
a_clicks = ad_clicks[
   ad_clicks.experimental_group
   == 'A']
b_clicks = ad_clicks[
  ad_clicks.experimental_group 
  == 'B']

#calculating the percent of users who clicked by day
a_click = a_clicks.groupby(['is_click', 'day']).user_id.count().reset_index()


a_click_pivot = a_click.pivot(
  columns='is_click',
  index='day',
  values='user_id'
).reset_index

b_click = b_clicks.groupby(['is_click', 'day']).user_id.count().reset_index()

b_click_pivot = b_click.pivot(
  columns='is_click',
  index='day',
  values='user_id'
).reset_index

print(a_click_pivot, b_click_pivot)
print(b_clicks)
print(ex_pivot)
print(ex)
print(ad_clicks.head(10))
print(clicks_by_source)
print(clicks_pivot)
