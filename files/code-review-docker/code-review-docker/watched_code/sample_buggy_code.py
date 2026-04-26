def calculate_discount(price, discount_percent):
    discounted = price - (price * discount_percent / 100)
    return discounted

def get_user_data(user_id):
    users = {1: "Alice", 2: "Bob", 3: "Charlie"}
    return users[user_id]

def divide(a, b):
    return a / b

items = [10, 20, 30, 40, 50]
total = 0
for i in range(len(items) + 1):
    total += items[i]

print(calculate_discount(100, 20))
print(get_user_data(5))
print(divide(10, 0))
print(total)
