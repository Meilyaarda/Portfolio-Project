#!/usr/bin/env python
# coding: utf-8

# In[19]:

#IMPORT LIBRARY
import pandas as pd
import seaborn as sns
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
import numpy as np
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8)  #Sesuaikan konfigurasi plot yang akan dibuat


# In[2]:


#READ DATA
df = pd.read_csv(r'D:\MEILYA THE DATA ANALYST\movies.csv')


# In[3]:


#######   MARI KITA LAKUKAN DATA CLEANING TERLEBIH DAHULU SEBELUM MELAKUKAN CORRELATION   #######
#Menampilkan data-data teratas

df.head()


# In[4]:


## Melihat adakah Mising Data
## Jika ada missing data isi dengan mean
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, round(pct_missing*100)))


# In[5]:


#Mengisi data yang kosong(NaN) pada kolom budget dan gross dengan 0.0
df['budget'] = df['budget'].fillna(0)
df['gross'] = df['gross'].fillna(0)


# In[6]:
#Melihat 50 data terbawah
df.tail(50)


# In[30]:


#Pisahkan tanggal rilis pada kolom released menjadi kolom baru
df['yearcorrect'] = df['released'].str.split('(', expand=True)
df.head(20)


# In[18]:


#Melihat tipe data setiap kolom
df.dtypes


# In[37]:

#Mengurutkan data berdasarkan kolom gross
df = df.sort_values(by=['gross'], inplace=False, ascending=False)


# In[14]:


#Mengubah tipe data gross menjadi int karena pada saat tipe data float nilai gross tidak valid(misal : 12345+6)
df = df.astype({'gross':'int'})


# In[15]:

#Melihat data
df


# In[34]:


#Melihat semua isi rows
pd.set_option('display.max_rows', None)


# In[35]:


#Menghapus duplikasi
df['company'].drop_duplicates().sort_values(ascending=False)


# In[39]:


#Korelasi Tingginya Budget
#Scatter Plot dengan Budget VS Gross

plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget VS Gross')
plt.xlabel('Gross Earning')
plt.ylabel('Budget for Film')

plt.show()


# In[40]:


#Menampilkan data dengan budget terbesar
df.head()


# In[41]:


#Plot Budget vs Gross menggunakan seaborn
#Line biru menunjukkan korelasi antara budget dan gross
sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color":"red"}, line_kws={"color":"blue"})


# In[43]:


#Melihat korelasinya
df.corr(method='pearson') #Gunakan method (pearson, kendall, spearman )


# In[45]:


#Korelasi tertinggi antara budget dan gross
correlation_matrix = df.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)

plt.title('Correlation Matric for Moive Features')
plt.xlabel('Movie Feature')
plt.ylabel('Movie Feature')

plt.show


# In[46]:


#Lihat Company
df.head()


# In[51]:


#Mengubah semua kolom yang memiliki tipe data objek menjadi numerik untuk melihat korelasi antar semua kolom
#Namun data kolom yang dirubah tipe datanya menjadi numeric tetap sesuai dengan tipe data sebelumnya
#Contohnya kolom company punya beberapa data yang bernama Marvel Studios, 
#setelah tipe datanya diubah menjadi numeric maka beberapa data bernama Marvel Studios itu akan menjadi 1606

df_numerized = df

for col_name in df_numerized.columns:
    if(df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes
        
df_numerized


# In[52]:


#Melihat korelasi semua kolom dengan mengubah correlation_matrix = df_numerized.corr(method='pearson')
#yang awalnya adalah correlation_matrix = df.corr(method='pearson') karena semua tipe datanya sudah dirubah menjadi numeric
correlation_matrix = df_numerized.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)

plt.title('Correlation Matric for Moive Features')
plt.xlabel('Movie Feature')
plt.ylabel('Movie Feature')

plt.show


# In[53]:


#Melihat korelasinya dengan tabel
df_numerized.corr()


# In[54]:


#Melihat korelasi per kolom
correlation_mat = df_numerized.corr()
corr_pairs = correlation_mat.unstack()
corr_pairs


# In[55]:


#Melihat korelasi dengan mengurutkannya/langsung antar kolom dengan kolom
sorted_pairs = corr_pairs.sort_values()
sorted_pairs


# In[56]:


#Mencari korelasi > 0.5 dengan sorted pairs
high_corr = sorted_pairs[(sorted_pairs) > 0.5]
high_corr


# In[ ]:


#Kesimpulan
#Votes dan budget memiliki korelasi tertinggi kepada pendapatan gross
#Company memiliki korelasi rendah

