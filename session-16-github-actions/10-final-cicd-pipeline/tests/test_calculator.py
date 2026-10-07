import pytest
from app.calculator import add, subtract, multiply, divide

@pytest.mark.parametrize("operation,a,b,result", [(add,10,5,15),(subtract,10,5,5),(multiply,10,5,50),(divide,10,5,2),(add,-2,1,-1),(multiply,0,5,0)])
def test_arithmetic(operation,a,b,result):
    assert operation(a,b) == result

def test_zero_divisor():
    with pytest.raises(ValueError, match="zero"):
        divide(1,0)
