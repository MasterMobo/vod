package com.vod.dto.response;

import java.util.List;

import com.vod.entities.Video;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetVideosResponse {
    private List<Video> data;
}