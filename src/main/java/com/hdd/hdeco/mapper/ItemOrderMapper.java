package com.hdd.hdeco.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.hdd.hdeco.domain.CartDTO;
import com.hdd.hdeco.domain.ItemDTO;
import com.hdd.hdeco.domain.ItemOrderDTO;
import com.hdd.hdeco.domain.OrderCancelDTO;
import com.hdd.hdeco.domain.OrderDetailDTO;
import com.hdd.hdeco.domain.OrderListDTO;
import com.hdd.hdeco.domain.UserDTO;

@Mapper
public interface ItemOrderMapper {

	public int insertOrder(ItemOrderDTO itemOrderDTO);
	public ItemOrderDTO selectUserOrder(int userNo);
	public UserDTO getUserByUserNo(int userNo);
	public CartDTO selectCartByItemAndUser(int itemNo, int userNo);
	public ItemDTO getFromItem(int itemNo);
	public void deleteOrder(String itemOrderNo);
	public int deleteCartByUserNo(int userNo);
	public int insertOrderDetail(OrderDetailDTO orderDetailDTO);
	// 주문 정보 
	public void orderInfo(ItemOrderDTO itemOrderDTO) throws Exception;
	// 주문 목록
	public List<ItemOrderDTO> orderList(ItemOrderDTO itemOrderDTO) throws Exception;
	// 특정 주문 목록
	public List<OrderListDTO> orderView(ItemOrderDTO itemOrderDTO) throws Exception;
	public OrderDetailDTO selectUserOrderDetail(int userNo);
	public void orderCancel(OrderCancelDTO orderCancelDTO);
	
	
	//바로구매 기능에 관련된 mapper
	public int deleteGoBuyItemNo(int userNo);
	public int insertGoBuyOrderDetail(OrderDetailDTO orderDetailDTO);
}
