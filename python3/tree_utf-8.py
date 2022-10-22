"""
用中文寫 python

有些 syntax 的保留字應該是沒辦法解決
像是： class, def, if 之類的

而 __init__ 這種 magic method 好像也沒辦法
"""


from random import shuffle as 洗牌
from builtins import range as 範圍
from builtins import list as 列表
from builtins import print as 列印
from builtins import int as 整數
from functools import reduce as 折疊


class 二元樹:
    def __init__(自己, 值: 整數):
        自己.左子樹 = None
        自己.右子樹 = None
        自己.值 = 值


def 插入(樹: 二元樹, 值) -> 二元樹:
    if not 樹:
        return 二元樹(值)
    if 值 > 樹.值:
        樹.右子樹 = 插入(樹.右子樹, 值)
    else:
        樹.左子樹 = 插入(樹.左子樹, 值)
    return 樹


def 反轉二元樹(根: 二元樹):
    if 根:
        反轉二元樹(根.左子樹)
        反轉二元樹(根.右子樹)
        根.左子樹, 根.右子樹 = 根.右子樹, 根.左子樹 


def 列印樹(根: 二元樹):
    if not 根:
        return
    列印樹(根.左子樹)
    列印(根.值)
    列印樹(根.右子樹)


def 主要():
    表 = 列表(範圍(10))
    洗牌(表)
    列印(表)

    樹 = 折疊(插入, 表, None)

    列印("=======")
    列印樹(樹)

    反轉二元樹(樹)
    
    列印("=======")
    列印樹(樹)

主要()
