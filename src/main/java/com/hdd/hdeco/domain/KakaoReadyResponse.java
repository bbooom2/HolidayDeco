package com.hdd.hdeco.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class KakaoReadyResponse {
	private String tid;
	private String next_redirect_pc_url;
	private String partner_order_id;
}